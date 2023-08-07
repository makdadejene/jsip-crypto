open! Types

module ArimaModel : sig
  type t =
    { mutable ar_model : Auto_regressor.AutoRegressor.t
    ; mutable weighted_average : float
    ; mutable mvg_model : Moving_average.MovingAverageModel.t
    ; mutable full_dataset : Total_Data.t
    ; mutable predictions : Prediction.t array
    }

  val sexp_of_t : t -> Sexplib0.Sexp.t
  val predictions : t -> Prediction.t array
  val full_dataset : t -> Total_Data.t
  val mvg_model : t -> Moving_average.MovingAverageModel.t
  val weighted_average : t -> float
  val ar_model : t -> Auto_regressor.AutoRegressor.t
  val create : Crypto.t -> ?weighted_average:float -> unit -> t

  val create_with_dataset
    :  dataset:Total_Data.t
    -> ?weighted_average:float
    -> unit
    -> t

  val update_dateset : 'a -> 'b -> 'a * 'b
  val predict_next_price : t -> Prediction.t
  val predict_all_prices : t -> int -> unit
  val data_graph_points : t -> (string * float) list
  val predictions_graph_points : t -> (string * float) array
  val all_graph_points : t -> (string * float) list * (string * float) array
end
