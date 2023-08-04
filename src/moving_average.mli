module Gp = Gnuplot

module MovingAverageModel : sig
  type t =
    { mutable q : int
    ; mutable moving_average_window : int
    ; mutable dataset : Types.Total_Data.t
    }

  val sexp_of_t : t -> Sexplib0.Sexp.t
  val q : t -> int
  val moving_avereage_window : t -> int
  val dataset : t -> Types.Total_Data.t

  val create
    :  dataset:Types.Total_Data.t
    -> ?q:int
    -> ?moving_average_window:int
    -> unit
    -> t

  val update_parameters : t -> int -> int -> unit
  val update_dateset : t -> new_dataset:Types.Total_Data.t -> unit

  val get_moving_avgs
    :  Types.Total_Data.t
    -> int
    -> (Types.Date.t * float) list

  val predict_next_price : t -> Types.Prediction.t
end
