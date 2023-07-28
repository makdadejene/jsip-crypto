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
        List.filteri close_list ~f:(fun index_rg _float ->
          if index_rg >= index_orig - (range - 1) && index_rg <= index_orig
          then true
          else false)
      in
      let sum = List.fold curr_range ~init:0.0 ~f:(fun sum x -> sum +. x) in
      result @ [ sum /. Int.to_float range ])
    else [])
;;

let%expect_test "mvg" =
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
