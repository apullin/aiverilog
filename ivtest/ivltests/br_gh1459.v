module test;

string a = "A";
string b = "B";

task t(input int verbosity);

    string color;
    color = (verbosity >= 3) ? a : b;

endtask

endmodule
