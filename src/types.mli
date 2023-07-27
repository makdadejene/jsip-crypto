open! Core

module Crypto : sig
  type t =
    | Bitcoin
    | Ethereum
    | XRP

  val get_data_file : t -> string
end

module Date : sig
  type t =
    { year : int
    ; month : int
    ; day : int
    }

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

  val create
    :  date:string
    -> open_:float
    -> high:float
    -> low:float
    -> close:float
    -> volume:int
    -> t
end

module Total_Data : sig
  type t =
    { crypto : Crypto.t
    ; mutable days : Day_Data.t list
    }
  [@@deriving compare, sexp_of]

  val create : Crypto.t -> t
  val add_day_data : t -> Day_Data.t -> unit
end
