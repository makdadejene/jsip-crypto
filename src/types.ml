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
    | Bitcoin -> "src/data/bitcoin_test.txt"
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
    let hour, minute =
      ( Int.of_string (List.nth_exn seperate_times 0)
      , Int.of_string (List.nth_exn seperate_times 1) )
    in
    { year; month; day; hour; minute }
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
  let add_day_data t day = t.data <- t.data @ [ day ]
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
  end

  include T
  include Comparable.Make (T)
end

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
