open! Core

let get_minute_data coin =
  let data_file = Types.Crypto.get_data_file coin in
  let curr_file = In_channel.read_lines data_file in
  let total_data = Types.Total_Minute_Data.create ~crypto:coin in
  List.iter curr_file ~f:(fun line ->
    let split_line = String.split line ~on:',' in
    let curr_list = List.tl_exn split_line in
    match curr_list with
    | time :: _filler :: price :: _ ->
      let price = Float.of_string price in
      let day = Types.Minute_Data.create ~time ~price in
      Types.Total_Minute_Data.add_day_data total_data day
    | _ -> ());
  total_data
;;

let get_day_data coin =
  let data_file = Types.Crypto.get_data_file coin in
  let curr_file = In_channel.read_lines data_file in
  let total_data = Types.Total_Data.create coin in
  List.iter curr_file ~f:(fun line ->
    let split_line = String.split line ~on:',' in
    match split_line with
    | date :: open_ :: high :: low :: close :: _ :: volume :: _ ->
      if not (String.equal open_ "null")
      then (
        let open_, high, low, close, volume =
          ( Float.of_string open_
          , Float.of_string high
          , Float.of_string low
          , Float.of_string close
          , Int.of_string volume )
        in
        let day =
          Types.Day_Data.create ~date ~open_ ~high ~low ~close ~volume ()
        in
        Types.Total_Data.add_day_data total_data day)
    | _ -> ());
  total_data
;;
