open! Core
open! Types
module Gp = Gnuplot

let coin_name = "Bitcoin"
let sample_list = [ 1.0, 2.0 ]

let test_ar_graph () =
  let total_data = Total_Data.create Crypto.Bitcoin in
  let days1 =
    List.init 9 ~f:(fun int ->
      Day_Data.create
        ~date:("2022-07-1" ^ Int.to_string (int + 1))
        ~close:(Int.to_float (int + 1))
        ())
  in
  let days2 =
    List.init 10 ~f:(fun int ->
      Day_Data.create
        ~date:("2022-07-2" ^ Int.to_string int)
        ~close:(Int.to_float (10 - int))
        ())
  in
  Total_Data.add_days_data total_data days1;
  Total_Data.add_days_data total_data days2;
  let model =
    Auto_regressor.AutoRegressor.create ~dataset:total_data ~p:5 ()
  in
  let prediction = Auto_regressor.AutoRegressor.predict_next_price model in
  let gp = Gp.create () in
  let data_points_series =
    Gp.Series.lines_xy
      ~color:`Green
      (List.map
         (Total_Data.get_all_dates_prices total_data ())
         ~f:(fun data_tuple ->
           Date.time_to_unix (fst data_tuple), snd data_tuple))
  in
  (* print_s [%message (List.map (Total_Data.get_all_dates_prices
     total_data ()) ~f:(fun data_tuple -> Date.time_to_unix (fst
     data_tuple), snd data_tuple) : (float * float) list)]; *)
  let prediction_series =
    Gp.Series.points_xy
      ~color:`Black
      [ (let unix_date =
           Date.time_to_unix
             (Prediction.date prediction)
         in
         let price = Prediction.prediction prediction in
         unix_date, price)
      ]
  in
  Gp.plot_many
    gp
    ~output:(Gp.Output.create (`Png "autoregressor_predictor_test.png"))
    [ data_points_series; prediction_series ];
  (* Gp.plot gp ~output:(Gp.Output.create (`Png
     "autoregressor_predictor_test.png")) data_points_series; *)
  Gp.close gp;
  print_s [%message (prediction : Prediction.t)]
;;

let test_mvg_graph () =
  let total_data = Total_Data.create Crypto.Bitcoin in
  let days1 =
    List.init 9 ~f:(fun int ->
      Day_Data.create
        ~date:("2022-07-1" ^ Int.to_string (int + 1))
        ~close:(Int.to_float (int + 1))
        ())
  in
  let days2 =
    List.init 10 ~f:(fun int ->
      Day_Data.create
        ~date:("2022-07-2" ^ Int.to_string int)
        ~close:(Int.to_float (10 - int))
        ())
  in
  Total_Data.add_days_data total_data days1;
  Total_Data.add_days_data total_data days2;
  let model =
    Moving_average.MovingAverageModel.create
      ~dataset:total_data
      ~q:5
      ~moving_average_window:10
      ()
  in
  let prediction =
    Moving_average.MovingAverageModel.predict_next_price model
  in
  let gp = Gp.create () in
  let data_points_series =
    Gp.Series.lines_xy
      ~color:`Green
      (List.map
         (Total_Data.get_all_dates_prices total_data ())
         ~f:(fun data_tuple ->
           Date.time_to_unix (fst data_tuple), snd data_tuple))
  in
  let mvg_data_points_series =
    Gp.Series.lines_xy
      ~color:`Blue
      (List.map
         (Moving_average.MovingAverageModel.get_moving_avgs
            total_data
            (Moving_average.MovingAverageModel.moving_avereage_window model))
         ~f:(fun data_tuple ->
           Date.time_to_unix (fst data_tuple), snd data_tuple))
  in
  let prediction_series =
    Gp.Series.points_xy
      ~color:`Magenta
      [ (let unix_date =
           Date.time_to_unix
             (Prediction.date prediction)
         in
         let price = Prediction.prediction prediction in
         unix_date, price)
      ]
  in
  Gp.plot_many
    gp
    ~output:
      (Gp.Output.create (`Png "mvg_predictor_large_window_large_q.png"))
    [ data_points_series; mvg_data_points_series; prediction_series ];
  Gp.close gp;
  print_s [%message (prediction : Prediction.t)]
;;

let test_simple_graph () =
  let total_data = Total_Data.create Crypto.Bitcoin in
  let days1 =
    List.init 9 ~f:(fun int ->
      Day_Data.create
        ~date:("2022-07-1" ^ Int.to_string (int + 1))
        ~close:(Int.to_float (int + 1))
        ())
  in
  let days2 =
    List.init 10 ~f:(fun int ->
      Day_Data.create
        ~date:("2022-07-2" ^ Int.to_string int)
        ~close:(Int.to_float (10 - int))
        ())
  in
  Total_Data.add_days_data total_data days1;
  Total_Data.add_days_data total_data days2;
  let model = Simple_model.ArimaModel.create ~dataset:total_data () in
  let prediction = Simple_model.ArimaModel.predict_next_price model in
  let gp = Gp.create () in
  let data_points_series =
    Gp.Series.lines_xy
      ~color:`Green
      (List.map
         (Total_Data.get_all_dates_prices total_data ())
         ~f:(fun data_tuple ->
           Date.time_to_unix (fst data_tuple), snd data_tuple))
  in
  let prediction_series =
    Gp.Series.points_xy
      ~color:`Magenta
      [ (let unix_date =
           Date.time_to_unix
             (Prediction.date prediction)
         in
         let price = Prediction.prediction prediction in
         unix_date, price)
      ]
  in
  Gp.plot_many
    gp
    ~output:(Gp.Output.create (`Png "arima_predictor_test.png"))
    [ data_points_series; prediction_series ];
  Gp.close gp;
  print_s [%message (prediction : Prediction.t)]
;;

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

let test_command =
  Command.basic
    ~summary:"this is the thingy"
    (let%map_open.Command () = return () in
     fun () ->
       test_ar_graph ();
       test_mvg_graph ();
       test_simple_graph ())
;;

let command =
  Command.group
    ~summary:"beep boop"
    [ "test", test_command; "visualize", visualize_command ]
;;
