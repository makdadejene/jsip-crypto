open! Core
open! Types
module Gp = Gnuplot

module MovingAverageModel = struct
  type t =
    { mutable q : int
    ; mutable moving_average_window : int
    ; mutable dataset : Total_Data.t
    }
  [@@deriving sexp_of]

  let q t = t.q
  let moving_avereage_window t = t.moving_average_window
  let dataset t = t.dataset

  let create ~dataset ?(q = 3) ?(moving_average_window = 5) () =
    { q; dataset; moving_average_window }
  ;;

  let update_parameters t q moving_average_window =
    t.q <- q;
    t.moving_average_window <- moving_average_window
  ;;

  let update_dateset t ~new_dataset = t.dataset <- new_dataset

  let get_moving_avgs (crypto_data : Total_Data.t) (range : int) =
    let days_list =
      match crypto_data with { crypto = _c; days = d } -> d
    in
    let close_list =
      List.fold
        days_list
        ~init:[]
        ~f:
          (fun
            result_list
            { date
            ; open_ = _open
            ; high = _hig
            ; low = _lo
            ; close = clo
            ; volume = _vol
            }
          -> result_list @ [ date, clo ])
    in
    List.foldi
      close_list
      ~init:[]
      ~f:(fun index_orig result (date, _close_val) ->
        if index_orig >= range - 1
        then (
          let curr_range =
            List.slice close_list (index_orig - (range - 1)) (index_orig + 1)
          in
          let sum =
            List.fold curr_range ~init:0.0 ~f:(fun sum (_date, value) ->
              sum +. value)
          in
          result @ [ date, sum /. Int.to_float range ])
        else [])
  ;;

  let predict_next_price t =
    let moving_averages =
      get_moving_avgs (dataset t) (moving_avereage_window t)
    in
    let crypto = Total_Data.crypto (dataset t) in
    let dataset = Total_Data.create_from_date_price crypto moving_averages in
    let training_dataset =
      Total_Data.last_n_days_dataset dataset ~num_of_days:(q t)
    in
    let model = Model.create () in
    let next_date = Total_Data.next_day_date training_dataset in
    let next_date_unix = Date.time_to_unix next_date in
    Model.fit model training_dataset;
    let prediction = Model.predict model ~x_val:next_date_unix in
    Prediction.create next_date prediction
  ;;
end

let%expect_test "mvg_test1" =
  let total_data = Total_Data.create Crypto.Bitcoin in
  let days =
    List.init 10 ~f:(fun int ->
      Day_Data.create
        ~date:("2022-07-2" ^ Int.to_string int)
        ~close:(Int.to_float int)
        ())
  in
  Total_Data.add_days_data total_data days;
  let moving_average_test =
    MovingAverageModel.get_moving_avgs total_data 2
  in
  print_s [%message (moving_average_test : (Date.t * float) list)];
  [%expect
    {|
    (moving_average_test
     ((((year 2022) (month 7) (day 21)) 0.5)
      (((year 2022) (month 7) (day 22)) 1.5)
      (((year 2022) (month 7) (day 23)) 2.5)
      (((year 2022) (month 7) (day 24)) 3.5)
      (((year 2022) (month 7) (day 25)) 4.5)
      (((year 2022) (month 7) (day 26)) 5.5)
      (((year 2022) (month 7) (day 27)) 6.5)
      (((year 2022) (month 7) (day 28)) 7.5)
      (((year 2022) (month 7) (day 29)) 8.5)))|}]
;;

let%expect_test "mvg_test2" =
  let total_data = Total_Data.create Crypto.Bitcoin in
  let day1 = Day_Data.create ~date:"2022-07-29" ~close:1.5 () in
  let day2 = Day_Data.create ~date:"2022-07-30" ~close:2.45 () in
  let day3 = Day_Data.create ~date:"2022-07-31" ~close:3.23 () in
  let day4 = Day_Data.create ~date:"2022-08-1" ~close:4.87 () in
  Total_Data.add_day_data total_data day1;
  Total_Data.add_day_data total_data day2;
  Total_Data.add_day_data total_data day3;
  Total_Data.add_day_data total_data day4;
  let moving_average_test =
    MovingAverageModel.get_moving_avgs total_data 2
  in
  print_s [%message (moving_average_test : (Date.t * float) list)];
  [%expect
    {|
    (moving_average_test
     ((((year 2022) (month 7) (day 30)) 1.975)
      (((year 2022) (month 7) (day 31)) 2.84)
      (((year 2022) (month 8) (day 1)) 4.05)))|}]
;;

let%expect_test "mvg_predictor_default" =
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
  let model = MovingAverageModel.create ~dataset:total_data () in
  let prediction = MovingAverageModel.predict_next_price model in
  print_s [%message (prediction : Prediction.t)];
  [%expect
    {|
    (prediction ((date ((year 2022) (month 7) (day 30))) (prediction 2)))|}]
;;

let%expect_test "mvg_predictor_large_window_large_q" =
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
    MovingAverageModel.create
      ~dataset:total_data
      ~q:5
      ~moving_average_window:10
      ()
  in
  let prediction = MovingAverageModel.predict_next_price model in
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
         (MovingAverageModel.get_moving_avgs
            total_data
            (MovingAverageModel.moving_avereage_window model))
         ~f:(fun data_tuple ->
           Date.time_to_unix (fst data_tuple), snd data_tuple))
  in
  let prediction_series =
    Gp.Series.points_xy
      ~color:`Magenta
      [ (let unix_date = Date.time_to_unix (Prediction.date prediction) in
         let price = Prediction.prediction prediction in
         price, unix_date)
      ]
  in
  Gp.plot_many
    gp
    ~output:
      (Gp.Output.create (`Png "mvg_predictor_large_window_large_q.png"))
    [ data_points_series; mvg_data_points_series; prediction_series ];
  Gp.close gp;
  print_s [%message (prediction : Prediction.t)];
  [%expect
    {|
    (prediction
     ((date ((year 2022) (month 7) (day 30))) (prediction 5.2000000000007276)))|}]
;;
