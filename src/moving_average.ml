open! Core

let get_moving_avgs (crypto_data : Types.Total_Data.t) (range : int) =
  let days_list = match crypto_data with { crypto = _c; days = d } -> d in
  let close_list =
    List.fold
      days_list
      ~init:[]
      ~f:
        (fun
          result_list
          { date = _date
          ; open_ = _open
          ; high = _hig
          ; low = _lo
          ; close = clo
          ; volume = _vol
          }
        -> result_list @ [ clo ])
  in
  List.foldi close_list ~init:[] ~f:(fun index_orig result _close_val ->
    if index_orig >= range - 1
    then (
      let curr_range =
        List.slice close_list (index_orig - (range - 1)) index_orig
      in
      let sum = List.fold curr_range ~init:0.0 ~f:(fun sum x -> sum +. x) in
      result @ [ sum /. Int.to_float range ])
    else [])
;;

let%expect_test "mvg_test1" =
  let total_data = Types.Total_Data.create Types.Crypto.Bitcoin in
  let days =
    List.init 10 ~f:(fun int ->
      Types.Day_Data.create
        ~date:"2022-07-29"
        ~open_:0.
        ~high:0.
        ~low:0.
        ~close:(Int.to_float int)
        ~volume:0)
  in
  Types.Total_Data.add_days_data total_data days;
  let moving_average_test = get_moving_avgs total_data 2 in
  print_s [%message (moving_average_test : float list)];
  [%expect {|(moving_average_test (0.5 1.5 2.5 3.5 4.5 5.5 6.5 7.5 8.5))|}]
;;

let%expect_test "mvg_test2" =
  let total_data = Types.Total_Data.create Types.Crypto.Bitcoin in
  let day1 =
    Types.Day_Data.create
      ~date:"2022-07-29"
      ~open_:0.
      ~high:0.
      ~low:0.
      ~close:1.5
      ~volume:0
  in
  let day2 =
    Types.Day_Data.create
      ~date:"2022-07-30"
      ~open_:0.
      ~high:0.
      ~low:0.
      ~close:2.45
      ~volume:0
  in
  let day3 =
    Types.Day_Data.create
      ~date:"2022-07-30"
      ~open_:0.
      ~high:0.
      ~low:0.
      ~close:3.23
      ~volume:0
  in
  let day4 =
    Types.Day_Data.create
      ~date:"2022-07-31"
      ~open_:0.
      ~high:0.
      ~low:0.
      ~close:4.87
      ~volume:0
  in
  Types.Total_Data.add_day_data total_data day1;
  Types.Total_Data.add_day_data total_data day2;
  Types.Total_Data.add_day_data total_data day3;
  Types.Total_Data.add_day_data total_data day4;
  let moving_average_test = get_moving_avgs total_data 2 in
  print_s [%message (moving_average_test : float list)];
  [%expect {|(moving_average_test (1.975 2.84 4.05))|}]
;;
