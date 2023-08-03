open! Core
module Gp = Gnuplot

let coin_name = "Bitcoin"
let sample_list = [ 1.0, 2.0 ]

let visualize_command =
  let open Command.Let_syntax in
  Command.basic
    ~summary:"test"
    (let%map_open () = return () in
     fun () ->
       let gp = Gp.create () in
       Gp.plot
         gp
         ~output:(Gp.Output.create (`Png (coin_name ^ ".png")))
         ~title:(coin_name ^ " Prediction Model")
         ~use_grid:true
         ~fill:(`Pattern 1)
         ~range:(Gp.XY (0.0, 360.0, 0.0, 23000.0))
         ~labels:(Gp.Labels.create ~x:"Dates" ~y:"Prices" ())
         ~format:"%b %d'%y"
         (Gnuplot.Series.lines_xy sample_list);
       Gp.close gp;
       printf !"Done! Wrote gnufile to %s!" "test_output.png")
;;
