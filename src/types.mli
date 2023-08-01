open! Core

module Crypto : sig
  type t =
    | Bitcoin
    | Ethereum
    | XRP
  [@@deriving compare, sexp_of]

  val get_data_file : t -> string
end

module Date : sig
  type t =
    { year : int
    ; month : int
    ; day : int
    }
  [@@deriving compare, sexp_of]

  val create : string -> t
end

module Day_Data : sig
  type t =
    { date : Date.t
    ; open_ : float
    ; high : float
    ; low : float
    ; close : float
    ; volume : int
    }
  [@@deriving compare, sexp_of]

  val create
    :  date:string
    -> open_:float
    -> high:float
    -> low:float
    -> close:float
    -> volume:int
    -> t

  val get_date : t -> Date.t
  val get_open_ : t -> float
  val get_high : t -> float
  val get_low : t -> float
  val get_close : t -> float
  val get_volume : t -> int
end

module Total_Data : sig
  type t =
    { crypto : Crypto.t
    ; mutable days : Day_Data.t list
    }
  [@@deriving compare, sexp_of]

  val create : Crypto.t -> t
  val add_day_data : t -> Day_Data.t -> unit
  val add_days_data : t -> Day_Data.t list -> unit

  val get_all_dates_prices
    :  t
    -> ?market_data_type:string
    -> unit
    -> (Date.t * float) list

  val get_all_dates_volume : t -> (Date.t * int) list
end
