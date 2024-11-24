//Copyright (C)2014-2024 Gowin Semiconductor Corporation.
//All rights reserved.
//File Title: IP file
//Tool Version: V1.9.10.02
//Part Number: GW5AT-LV60PG484AC1/I0
//Device: GW5AT-60
//Device Version: B
//Created Time: Thu Nov 21 21:42:07 2024

module Gowin_OSC (oscout, oscen);

output oscout;
input oscen;

OSCA osc_inst (
    .OSCOUT(oscout),
    .OSCEN(oscen)
);

defparam osc_inst.FREQ_DIV = 3;

endmodule //Gowin_OSC
