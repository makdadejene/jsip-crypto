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
    | Bitcoin -> "src/bitcoin_data.txt"
    | Ethereum -> "src/ethereum_data.txt"
    | XRP -> "src/xrp_data.txt"
  ;;
end

(* module Day = struct module T = struct type t = { price : Price.t ; time :
   Time.t ; volume : Volume.t ; low : Low.t ; high : High.t ; market_cap :
   Market.t } [@@deriving compare, sexp] end

   include T include Comparable.Make (T) end *)

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

  let create date =
    let date_list = String.split date ~on:'-' in
    let year, month, day =
      ( Int.of_string (List.nth_exn date_list 0)
      , Int.of_string (List.nth_exn date_list 1)
      , Int.of_string (List.nth_exn date_list 2) )
    in
    { year; month; day }
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
  end

  include T
  include Comparable.Make (T)
end
