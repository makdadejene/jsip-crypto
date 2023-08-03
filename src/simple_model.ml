open! Core
open! Auto_regressor
open! Moving_average

let data = Fetch_data.get_day_data Bitcoin
let calculate_sma _length_of_window = ()

module ArimaModel = struct
  type t =
    { mutable ar_model : AutoRegressor.t
    ; mutable weighted_average : float
    ; mutable mvg_model : MovingAverageModel.t
    ; mutable full_dataset : Types.Total_Data.t
    }

  let update_dateset t dataset = t, dataset ;;

  (* let next_price t = 
    let ar_model_prediction =  in 
    let mvg_model_prediction =  in *)

end
