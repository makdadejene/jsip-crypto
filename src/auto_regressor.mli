module Prediction : sig
  type t =
    { date : Types.Date.t
    ; prediction : float
    }

  val sexp_of_t : t -> Sexplib0.Sexp.t
  val prediction : t -> float
  val date : t -> Types.Date.t
  val create : Types.Date.t -> float -> t
end

module Hyperparameters : sig
  type t =
    { constant_term : int
    ; regression_of_previous_val : int
    ; model_residual : int
    }

  val get_constant_term : t -> int
  val get_regression_of_previous_val : t -> int
  val get_model_residual : t -> int
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
  val fit : t -> Types.Total_Data.t -> unit
  val predict : t -> x_val:float -> float
end

module AutoRegressor : sig
  type t =
    { mutable p : int
    ; mutable dataset : Types.Total_Data.t
    }

  val p : t -> int
  val dataset : t -> Types.Total_Data.t
  val create : dataset:Types.Total_Data.t -> ?p:int -> unit -> t
  val update_parameters : t -> int -> unit
  val update_dateset : t -> new_dataset:Types.Total_Data.t -> unit
  val predict_next_price : t -> Prediction.t
end
