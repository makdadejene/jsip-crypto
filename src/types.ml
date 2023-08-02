open Core

module Crypto = struct
  module T = struct
    type t =
      | Bitcoin
      | Ethereum
      | XRP
    [@@deriving compare, sexp]
  end

  include T
  include Comparable.Make (T)

  let get_data_file t =
    match t with
    | Bitcoin -> "data/btc_data.txt"
    | Ethereum -> "data/ethereum_data.txt"
    | XRP -> "data/xrp_data.txt"
  ;;
end

module Time = struct
  module T = struct
    type t =
      { year : int
      ; month : int
      ; day : int
      ; hour : int
      ; minute : int
      ; seconds : int
      }
    [@@deriving compare, sexp]
  end

  include T
  include Comparable.Make (T)

  let create minute_string =
    let time_list = String.split minute_string ~on:' ' in
    let total_dates = List.hd_exn time_list in
    let seperate_dates = String.split total_dates ~on:'-' in
    let year, month, day =
      ( Int.of_string (List.nth_exn seperate_dates 0)
      , Int.of_string (List.nth_exn seperate_dates 1)
      , Int.of_string (List.nth_exn seperate_dates 2) )
    in
    let minute_list = String.concat (List.tl_exn time_list) in
    let seperate_times = String.split minute_list ~on:':' in
    let hour, minute, seconds =
      ( Int.of_string (List.nth_exn seperate_times 0)
      , Int.of_string (List.nth_exn seperate_times 1)
      , 0 )
    in
    { year; month; day; hour; minute; seconds }
  ;;
end

module Minute_Data = struct
  module T = struct
    type t =
      { time : Time.t
      ; price : float
      }
    [@@deriving compare, sexp]
  end

  include T
  include Comparable.Make (T)

  let create ~time ~price =
    let time = Time.create time in
    { time; price }
  ;;
end

module Total_Minute_Data = struct
  module T = struct
    type t =
      { crypto : Crypto.t
      ; mutable data : Minute_Data.t list
      }
    [@@deriving compare, sexp]
  end

  include T
  include Comparable.Make (T)

  let create ~crypto = { crypto; data = [] }
  let add_day_data t day = t.data <- day :: t.data
end

module Date = struct
  module T = struct
    type t =
      { year : int
      ; month : int
      ; day : int
      }
    [@@deriving compare, sexp]
  end

  include T
  include Comparable.Make (T)

  let create date_string =
    let date_list = String.split date_string ~on:'-' in
    let year, month, day =
      ( Int.of_string (List.nth_exn date_list 0)
      , Int.of_string (List.nth_exn date_list 1)
      , Int.of_string (List.nth_exn date_list 2) )
    in
    { year; month; day }
  ;;

  let time_to_unix date_string =
    let utc_string = date_string ^ " 00:00:00Z" in
    Time_ns.to_span_since_epoch
      (Time_ns.of_string_with_utc_offset utc_string)
    |> Time_ns.Span.to_sec
  ;;

  let unix_to_time (unix_string : string) =
    unix_string
    |> Int.of_string
    |> Time_ns.Span.of_int_sec
    |> Time_ns.of_span_since_epoch
    |> Time_ns.to_string_utc
  ;;

  let%expect_test _ =
    let test s =
      let result = unix_to_time s in
      print_endline result
    in
    test "1444356660";
    [%expect {| 2015-10-09 02:11:00.000000000Z |}];
    test "1690921547";
    [%expect {| 2023-08-01 20:25:47.000000000Z |}]
  ;;

  let is_leap_year t =
    let year = t.year in
    let open Int in
    year % 4 = 0 && (year % 100 <> 0 || year % 400 = 0)
  ;;

  let next_date t =
    let year, month, day = t.year, t.month, t.day in
    match month with
    | 1 | 3 | 5 | 7 | 8 | 10 ->
      if Int.equal day 31
      then { year; month = month + 1; day = 1 }
      else { year; month; day = day + 1 }
    | 12 ->
      if Int.equal day 31
      then { year = year + 1; month = 1; day = 1 }
      else { year; month; day = day + 1 }
    | 4 | 6 | 9 | 11 ->
      if Int.equal day 30
      then { year; month = month + 1; day = 1 }
      else { year; month; day = day + 1 }
    | 2 ->
      if Int.equal day 28
      then
        if is_leap_year t
        then { year; month; day = day + 1 }
        else { year; month = month + 1; day = 1 }
      else if Int.equal day 29
      then { year; month = month + 1; day = 1 }
      else { year; month; day = day + 1 }
    | _ -> t
  ;;
end

module Day_Data = struct
  module T = struct
    type t =
      { date : Date.t
      ; open_ : float
      ; high : float
      ; low : float
      ; close : float
      ; volume : int
      }
    [@@deriving compare, sexp]
  end

  include T
  include Comparable.Make (T)

  let create ~date ~open_ ~high ~low ~close ~volume =
    let date = Date.create date in
    { date; open_; high; low; close; volume }
  ;;

  let get_date t = t.date
  let get_open_ t = t.open_
  let get_high t = t.high
  let get_low t = t.low
  let get_close t = t.close
  let get_volume t = t.volume
end

module Total_Data = struct
  module T = struct
    type t =
      { crypto : Crypto.t
      ; mutable days : Day_Data.t list
      }
    [@@deriving compare, sexp]

    let crypto t = t.crypto
    let days t = t.days
    let create crypto = { crypto; days = [] }
    let add_day_data t day = t.days <- t.days @ [ day ]
    let add_days_data t days = t.days <- t.days @ days

    let get_all_dates_prices t ?(market_data_type = "close") () =
      match market_data_type with
      | "close" ->
        List.map t.days ~f:(fun day ->
          Day_Data.get_date day, Day_Data.get_close day)
      | "open_" ->
        List.map t.days ~f:(fun day ->
          Day_Data.get_date day, Day_Data.get_open_ day)
      | "high" ->
        List.map t.days ~f:(fun day ->
          Day_Data.get_date day, Day_Data.get_high day)
      | "low" ->
        List.map t.days ~f:(fun day ->
          Day_Data.get_date day, Day_Data.get_low day)
      | _ -> failwith ("Incorrect market type given: " ^ market_data_type)
    ;;

    let get_all_dates_volume t =
      List.map t.days ~f:(fun day ->
        Day_Data.get_date day, Day_Data.get_volume day)
    ;;

    let last_n_days_dataset t ~num_of_days =
      if num_of_days > List.length (days t)
      then
        failwith
          "(num_of_days) is greater than the number of days in the dataset"
      else (
        let days = List.rev (List.take (List.rev (days t)) num_of_days) in
        { crypto = crypto t; days })
    ;;
  end

  include T
  include Comparable.Make (T)
end

let%expect_test "unix_1" =
  let to_unix = Date.time_to_unix "2022-07-26" in
  print_s [%message (to_unix : float)];
  [%expect {| (to_unix 1658793600) |}]
;;

let%expect_test "unix_2" =
  let to_unix = Date.unix_to_time "1444356660" in
  print_s [%message (to_unix : string)];
  [%expect {| (to_unix "2015-10-09 02:11:00.000000000Z")
   |}]
;;

let%expect_test "next_date1" =
  let next_date =
    Date.next_date { Date.year = 2001; month = 12; day = 30 }
  in
  print_s [%message (next_date : Date.t)];
  [%expect {| (next_date ((year 2001) (month 12) (day 31))) |}]
;;

let%expect_test "next_date2" =
  let next_date =
    Date.next_date { Date.year = 2001; month = 12; day = 31 }
  in
  print_s [%message (next_date : Date.t)];
  [%expect {| (next_date ((year 2002) (month 1) (day 1))) |}]
;;

let%expect_test "next_date3" =
  let next_date = Date.next_date { Date.year = 1900; month = 2; day = 28 } in
  print_s [%message (next_date : Date.t)];
  [%expect {| (next_date ((year 1900) (month 3) (day 1))) |}]
;;

let%expect_test "get_all_dates_prices1" =
  let total_data = Total_Data.create Crypto.Bitcoin in
  let days =
    List.init 10 ~f:(fun int ->
      Day_Data.create
        ~date:("2022-07-2" ^ Int.to_string int)
        ~open_:0.
        ~high:0.
        ~low:0.
        ~close:(Int.to_float int)
        ~volume:0)
  in
  Total_Data.add_days_data total_data days;
  let dates_prices_data = Total_Data.get_all_dates_prices total_data () in
  print_s [%message (dates_prices_data : (Date.t * float) list)];
  [%expect
    {|
    (dates_prices_data
     ((((year 2022) (month 7) (day 20)) 0) (((year 2022) (month 7) (day 21)) 1)
      (((year 2022) (month 7) (day 22)) 2) (((year 2022) (month 7) (day 23)) 3)
      (((year 2022) (month 7) (day 24)) 4) (((year 2022) (month 7) (day 25)) 5)
      (((year 2022) (month 7) (day 26)) 6) (((year 2022) (month 7) (day 27)) 7)
      (((year 2022) (month 7) (day 28)) 8) (((year 2022) (month 7) (day 29)) 9)))
      |}]
;;

let%expect_test "last_n_days_dataset1" =
  let total_data = Total_Data.create Crypto.Bitcoin in
  let days =
    List.init 10 ~f:(fun int ->
      Day_Data.create
        ~date:("2022-07-2" ^ Int.to_string int)
        ~open_:0.
        ~high:0.
        ~low:0.
        ~close:(Int.to_float int)
        ~volume:0)
  in
  Total_Data.add_days_data total_data days;
  let last_n_days =
    Total_Data.last_n_days_dataset total_data ~num_of_days:3
  in
  print_s [%message (last_n_days : Total_Data.t)];
  [%expect
    {|
    (last_n_days
     ((crypto Bitcoin)
      (days
       (((date ((year 2022) (month 7) (day 27))) (open_ 0) (high 0) (low 0)
         (close 7) (volume 0))
        ((date ((year 2022) (month 7) (day 28))) (open_ 0) (high 0) (low 0)
         (close 8) (volume 0))
        ((date ((year 2022) (month 7) (day 29))) (open_ 0) (high 0) (low 0)
         (close 9) (volume 0))))))
      |}]
;;

let%expect_test "last_n_days_dataset2" =
  let total_data = Total_Data.create Crypto.Bitcoin in
  let days =
    List.init 10 ~f:(fun int ->
      Day_Data.create
        ~date:("2022-07-2" ^ Int.to_string int)
        ~open_:0.
        ~high:0.
        ~low:0.
        ~close:(Int.to_float int)
        ~volume:0)
  in
  Total_Data.add_days_data total_data days;
  let last_n_days =
    Total_Data.last_n_days_dataset total_data ~num_of_days:5
  in
  print_s [%message (last_n_days : Total_Data.t)];
  [%expect
    {|
    (last_n_days
     ((crypto Bitcoin)
      (days
       (((date ((year 2022) (month 7) (day 25))) (open_ 0) (high 0) (low 0)
         (close 5) (volume 0))
        ((date ((year 2022) (month 7) (day 26))) (open_ 0) (high 0) (low 0)
         (close 6) (volume 0))
        ((date ((year 2022) (month 7) (day 27))) (open_ 0) (high 0) (low 0)
         (close 7) (volume 0))
        ((date ((year 2022) (month 7) (day 28))) (open_ 0) (high 0) (low 0)
         (close 8) (volume 0))
        ((date ((year 2022) (month 7) (day 29))) (open_ 0) (high 0) (low 0)
         (close 9) (volume 0))))))
      |}]
;;

let%expect_test "last_n_days_dataset3" =
  let total_data = Total_Data.create Crypto.Bitcoin in
  let days =
    List.init 10 ~f:(fun int ->
      Day_Data.create
        ~date:("2022-07-2" ^ Int.to_string int)
        ~open_:0.
        ~high:0.
        ~low:0.
        ~close:(Int.to_float int)
        ~volume:0)
  in
  Total_Data.add_days_data total_data days;
  let last_n_days =
    Total_Data.last_n_days_dataset total_data ~num_of_days:11
  in
  print_s [%message (last_n_days : Total_Data.t)];
  [%expect.unreachable]
  [@@expect.uncaught_exn
    {|
  (* CR expect_test_collector: This test expectation appears to contain a backtrace.
     This is strongly discouraged as backtraces are fragile.
     Please change this test to not include a backtrace. *)

  (Failure "(num_of_days) is greater than the number of days in the dataset")
  Raised at Stdlib.failwith in file "stdlib.ml", line 29, characters 17-33
  Called from Crypto_src__Types.(fun) in file "src/types.ml", line 397, characters 4-61
  Called from Expect_test_collector.Make.Instance_io.exec in file "collector/expect_test_collector.ml", line 234, characters 12-19 |}]
;;
