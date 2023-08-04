module ArimaModel : sig
  type t =
    { mutable ar_model : Auto_regressor.AutoRegressor.t
    ; mutable weighted_average : float
    ; mutable mvg_model : Moving_average.MovingAverageModel.t
    ; mutable full_dataset : Types.Total_Data.t
    ; mutable predictions : Auto_regressor.Prediction.t list
    }

  val sexp_of_t : t -> Sexplib0.Sexp.t
  val predictions : t -> Auto_regressor.Prediction.t list
  val full_dataset : t -> Types.Total_Data.t
  val mvg_model : t -> Moving_average.MovingAverageModel.t
  val weighted_average : t -> float
  val ar_model : t -> Auto_regressor.AutoRegressor.t

  val create
    :  dataset:Types.Total_Data.t
    -> ?weighted_average:float
    -> unit
    -> t

  val update_dateset : 'a -> 'b -> 'a * 'b
  val predict_next_price : t -> Auto_regressor.Prediction.t
  val graph_points : t -> (string * float) list * (string * float) list
end
