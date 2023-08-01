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

  let unix_to_time unix_string =
    Time_ns.of_span_since_epoch unix_string |> Time_ns.to_string_utc
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
  end

  include T
  include Comparable.Make (T)
end

let%expect_test "unix_1" =
  let to_unix = Date.time_to_unix "2022-07-26" in
  print_s [%message (to_unix : float)];
  [%expect {| (to_unix 1658808000) |}]
;;

let%expect_test "unix_2" =
  let to_unix = Date.unix_to_time "1444356660" in
  print_s [%message (to_unix : string)];
  [%expect {| (to_unix 1658808000) |}]
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
