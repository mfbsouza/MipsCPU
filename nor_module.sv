module nor_module(input logic a, input logic b, output logic s);

assign s = !(a || b);

endmodule: nor_module