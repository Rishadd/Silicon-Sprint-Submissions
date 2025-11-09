// fpu.v
// IEEE-754 half-precision (16-bit) FPU: FADD and FMUL
// Inputs: a,b as 16-bit IEEE-754 half floats
// aluctrl selects the operation
// Outputs: result (16-bit half), zero flag

module fpu (
  input [15:0] a, b,
  input [3:0] aluctrl,
  output reg [15:0] result,
  output zero
);
`include "instruction_defs.v"

wire sign_a = a[15];
wire [4:0] exp_a = a[14:10];
wire [9:0] mant_a = {1'b0, a[9:0]}; // we'll handle implicit 1 for normalized

wire sign_b = b[15];
wire [4:0] exp_b = b[14:10];
wire [9:0] mant_b = {1'b0, b[9:0]};

function [31:0] half_to_real;
  input [15:0] h;
  real r;
  begin
    // careful: Verilog doesn't allow returning real from function.
    // Instead we encode float bits into a 32-bit single-precision IEEE-754 via algorithmic conversion.
    // For simulation correctness we convert via double-real arithmetic using $bitstoreal not allowed.
    // Simpler approach: perform operations using SystemVerilog real via tasks is not portable.
    // Instead we implement bit-level half add/mul approximations via built-in real using $realtobits/$bitstoreal not standard in all simulators.
    // We will not use this function; instead we implement add/mul via a simple software-like algorithm below.
    half_to_real = 32'h00000000;
  end
endfunction

// For simplicity and correctness for simulation, implement using a small helper:
// Convert half to double real using integer decode, do arithmetic in real, convert back.
// Many simulators support $bitstoreal / $realtobits; but to keep compatibility we'll do manual operations.

function [15:0] half_add;
  input [15:0] x;
  input [15:0] y;
  real rx, ry, rz;
  integer signx, signy, signz;
  reg [15:0] out;
  begin
    // decode x to real
    if (x[14:10] == 5'h1F) begin
      // Inf/NaN -> pass through
      out = x; half_add = out; disable half_add;
    end
    rx = 0.0; ry = 0.0;
    // convert half to real
    signx = x[15] ? -1 : 1;
    if (x[14:10] == 0) begin
      // subnormal or zero
      rx = signx * ( (x[9:0]) / (2.0**10) ) * (2.0 ** (1-15));
    end else begin
      rx = signx * (1.0 + (x[9:0]) / (2.0**10)) * (2.0 ** (x[14:10] - 15));
    end
    signy = y[15] ? -1 : 1;
    if (y[14:10] == 0) begin
      ry = signy * ( (y[9:0]) / (2.0**10) ) * (2.0 ** (1-15));
    end else begin
      ry = signy * (1.0 + (y[9:0]) / (2.0**10)) * (2.0 ** (y[14:10] - 15));
    end

    rz = rx + ry;

    // convert rz back to half
    if (rz == 0.0) begin
      out = 16'h0000;
    end else begin
      signz = (rz < 0.0) ? 1 : 0;
      if (rz < 0.0) rz = -rz;
      // exponent
      integer e;
      real m;
      e = $clog2(rz); // not synthesizable, but exists in many simulators
      // safer calculation:
      e = 0;
      real tmp = rz;
      while (tmp >= 2.0) begin tmp = tmp/2.0; e = e+1; end
      while (tmp < 1.0) begin tmp = tmp*2.0; e = e-1; end
      m = tmp; // in [1,2)
      integer exp_half = e + 15;
      if (exp_half <= 0) begin
        // subnormal
        real frac = rz / (2.0**(1-15));
        integer mant = $rtoi(frac * (2.0**10) + 0.5);
        out = {signz, 5'b00000, mant[9:0]};
      end else if (exp_half >= 31) begin
        // overflow to inf
        out = {signz, 5'b11111, 10'b0};
      end else begin
        real frac = m - 1.0;
        integer mant = $rtoi(frac * (2.0**10) + 0.5);
        out = {signz, exp_half[4:0], mant[9:0]};
      end
    end
    half_add = out;
  end
endfunction

function [15:0] half_mul;
  input [15:0] x;
  input [15:0] y;
  real rx, ry, rz;
  reg [15:0] out;
  integer signx, signy, signz;
  begin
    // decode to real
    signx = x[15] ? -1 : 1;
    if (x[14:10] == 0) rx = signx * ( (x[9:0]) / (2.0**10) ) * (2.0 ** (1-15));
    else rx = signx * (1.0 + (x[9:0]) / (2.0**10)) * (2.0 ** (x[14:10] - 15));
    signy = y[15] ? -1 : 1;
    if (y[14:10] == 0) ry = signy * ( (y[9:0]) / (2.0**10) ) * (2.0 ** (1-15));
    else ry = signy * (1.0 + (y[9:0]) / (2.0**10)) * (2.0 ** (y[14:10] - 15));

    rz = rx * ry;

    // convert back (same method as add)
    if (rz == 0.0) begin
      out = 16'h0000;
    end else begin
      signz = (rz < 0.0) ? 1 : 0;
      if (rz < 0.0) rz = -rz;
      integer e;
      real tmp = rz;
      e = 0;
      while (tmp >= 2.0) begin tmp = tmp/2.0; e = e+1; end
      while (tmp < 1.0) begin tmp = tmp*2.0; e = e-1; end
      real m = tmp;
      integer exp_half = e + 15;
      if (exp_half <= 0) begin
        real frac = rz / (2.0**(1-15));
        integer mant = $rtoi(frac * (2.0**10) + 0.5);
        out = {signz, 5'b00000, mant[9:0]};
      end else if (exp_half >= 31) begin
        out = {signz, 5'b11111, 10'b0};
      end else begin
        real frac = m - 1.0;
        integer mant = $rtoi(frac * (2.0**10) + 0.5);
        out = {signz, exp_half[4:0], mant[9:0]};
      end
    end

    half_mul = out;
  end
endfunction

assign zero = (result == 16'h0000);

always @(*) begin
  case (aluctrl)
    `FPU_FADD: result = half_add(a,b);
    `FPU_FMUL: result = half_mul(a,b);
    default: result = 16'h0000;
  endcase
end

endmodule
