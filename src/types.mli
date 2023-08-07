open! Core

module Crypto : sig
  type t =
    | Bitcoin
    | Ethereum
    | XRP
  [@@deriving compare, sexp_of, enumerate, hash]

  val get_data_file : t -> string
end

module Time : sig
  type t =
    { year : int
    ; month : int
    ; day : int
    ; hour : int
    ; minute : int
    ; seconds : int
    }
  [@@deriving compare, sexp_of]

  val create : string -> t
end

module Minute_Data : sig
  type t =
    { time : Time.t
    ; price : float
    }
  [@@deriving compare, sexp_of]

  val create : time:string -> price:float -> t
end

module Total_Minute_Data : sig
  type t =
    { crypto : Crypto.t
    ; mutable data : Minute_Data.t list
    }
  [@@deriving compare, sexp_of]

  val create : crypto:Crypto.t -> t
  val add_day_data : t -> Minute_Data.t -> unit
end

module Date : sig
  type t =
    { year : int
    ; month : int
    ; day : int
    }
  [@@deriving equal, compare, sexp_of]

  val create : string -> t
  val time_to_unix : t -> float
  val unix_to_time : string -> string
  val day : t -> int
  val month : t -> int
  val year : t -> int
  val to_string : t -> string
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
    -> ?open_:float
    -> ?high:float
    -> ?low:float
    -> ?close:float
    -> ?volume:int
    -> unit
    -> t

  val create_with_date
    :  date:Date.t
    -> ?open_:float
    -> ?high:float
    -> ?low:float
    -> ?close:float
    -> ?volume:int
    -> unit
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

  val crypto : t -> Crypto.t
  val days : t -> Day_Data.t list
  val create : Crypto.t -> t
  val create_from_date_price : Crypto.t -> (Date.t * float) list -> t
  val add_day_data : t -> Day_Data.t -> unit
  val add_days_data : t -> Day_Data.t list -> unit
  val remove_first_day_data : t -> unit

  val get_all_dates_prices
    :  t
    -> ?market_data_type:string
    -> unit
    -> (Date.t * float) list

  val get_all_dates_volume : t -> (Date.t * int) list
  val get_first_day : t -> Day_Data.t
  val get_last_day : t -> Day_Data.t
  val next_day_date : t -> Date.t
  val last_n_days_dataset : t -> num_of_days:int -> t
end

module Prediction : sig
  type t =
    { date : Date.t
    ; prediction : float
    }

  val sexp_of_t : t -> Sexplib0.Sexp.t
  val prediction : t -> float
  val date : t -> Date.t
  val create : Date.t -> float -> t

  val average_predictions
    :  first_prediction:t
    -> second_prediction:t
    -> prediction_coeff:float
    -> t

  val compare : t -> t -> int
end

module Model : sig
  type t =
    { mutable weight : float
    ; mutable bias : float
    }

  val create : unit -> t
  val weight : t -> float
  val bias : t -> float
  val linear_regression_function : (float * float) list -> float * float
  val fit : t -> Total_Data.t -> unit
  val predict : t -> x_val:float -> float
end
