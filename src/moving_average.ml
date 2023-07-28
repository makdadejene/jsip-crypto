open! Core

let get_moving_avgs (crypto_data : Types.Total_Data.t) (range : int) =
  let days_list = match crypto_data with { crypto = _c; days = d } -> d in
  let close_list =
    List.fold
      days_list
      ~init:[]
      ~f:(fun
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
        List.slice close_list (index_orig - (range - 1)) index_orig
      in
      let sum =
        List.fold curr_range ~init:0.0 ~f:(fun sum (_date, value) ->
          sum +. value)
      in
      result @ [ date, sum /. Int.to_float range ])
    else [])
;;

let%expect_test "mvg_test1" =
  let total_data = Types.Total_Data.create Types.Crypto.Bitcoin in
  let days =
    List.init 10 ~f:(fun int ->
      Types.Day_Data.create
        ~date:("2022-07-2" ^ Int.to_string int)
        ~open_:0.
        ~high:0.
        ~low:0.
        ~close:(Int.to_float int)
        ~volume:0)
  in
  Types.Total_Data.add_days_data total_data days;
  let moving_average_test = get_moving_avgs total_data 2 in
  print_s [%message (moving_average_test : (Types.Date.t * float) list)];
  [%expect {|
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
      ~date:"2022-07-31"
      ~open_:0.
      ~high:0.
      ~low:0.
      ~close:3.23
      ~volume:0
  in
  let day4 =
    Types.Day_Data.create
      ~date:"2022-08-1"
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
  print_s [%message (moving_average_test : (Types.Date.t * float) list)];
  [%expect {|
    (moving_average_test
     ((((year 2022) (month 7) (day 30)) 1.975)
      (((year 2022) (month 7) (day 31)) 2.84)
      (((year 2022) (month 8) (day 1)) 4.05)))|}]
;;
