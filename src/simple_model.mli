open! Types

module ArimaModel : sig
  type t =
    { mutable ar_model : Auto_regressor.AutoRegressor.t
    ; mutable weighted_average : float
    ; mutable mvg_model : Moving_average.MovingAverageModel.t
    ; mutable full_dataset : Total_Data.t
    ; mutable predictions : Prediction.t list
    }

  val sexp_of_t : t -> Sexplib0.Sexp.t
  val predictions : t -> Prediction.t list
  val full_dataset : t -> Total_Data.t
  val mvg_model : t -> Moving_average.MovingAverageModel.t
  val weighted_average : t -> float
  val ar_model : t -> Auto_regressor.AutoRegressor.t
  val create : dataset:Total_Data.t -> ?weighted_average:float -> unit -> t
  val update_dateset : 'a -> 'b -> 'a * 'b
  val predict_next_price : t -> Prediction.t
  val graph_points : t -> (string * float) list * (string * float) list
end
