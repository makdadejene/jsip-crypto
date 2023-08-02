open! Core
open! Auto_regressor
open! Moving_average

let data = Fetch_data.get_day_data Bitcoin
let calculate_sma _length_of_window = ()

module ArimaModel = struct
  type t =
    { ar_model : AutoRegressor.t
    ; weighted_average : float
    }

  let next_price t = t ;;

end
