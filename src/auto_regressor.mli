module AutoRegressor : sig
  type t =
    { mutable p : int
    ; mutable dataset : Types.Total_Data.t
    }

  val sexp_of_t : t -> Sexplib0.Sexp.t
  val p : t -> int
  val dataset : t -> Types.Total_Data.t
  val create : dataset:Types.Total_Data.t -> ?p:int -> unit -> t
  val update_parameters : t -> int -> unit
  val update_dateset : t -> new_dataset:Types.Total_Data.t -> unit
  val predict_next_price : t -> Types.Prediction.t
end
