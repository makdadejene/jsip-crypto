module Gp = Gnuplot

val coin_name : string
val sample_list : (float * float) list
val visualize_command : Command.t
val test_graph_data : unit -> unit
val test_graph_data2 : unit -> Sexplib0.Sexp.t
val command : Command.t
