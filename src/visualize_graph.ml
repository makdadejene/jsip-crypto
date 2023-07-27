open! Core
module Gp = Gnuplot

let visualize_command =
  let open Command.Let_syntax in
  Command.basic
    ~summary:"test"
    (let%map_open () = return () in
     fun () ->
       let gp = Gp.create () in
       Gp.plot_many
         gp
         ~range:(Gp.XY (-10., 10., -1.5, 1.5))
         ~output:(Gp.Output.create (`Png "test_output.png"))
         [ Gp.Series.lines_func "sin(x)" ~title:"Plot a line" ~color:`Blue
         ; Gp.Series.points_func "cos(x)" ~title:"Plot points" ~color:`Green
         ];
       Gp.close gp;
       (* ignore (input_file : File_path.t); ignore (output_file :
          File_path.t); *)
       printf !"Done! Wrote dot file to %s!" "test_output.png")
;;
