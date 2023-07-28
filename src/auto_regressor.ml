open! Core

module Prediction = struct
  type t = {
    date : Types.Date.t
    ; price : int
  }
end

module Hyperparameters = struct
  type t = {
    constant_term : int 
    ; regression_of_previous_val : int
    ; model_residual : int
  }
  
  let get_constant_term t = t.constant_term ;;

  let get_regression_of_previous_val t = t.regression_of_previous_val ;;

  let get_model_residual t = t.model_residual ;;
end

module AutoRegressor = struct
  type t =
      { time_steps : int
      ; prediction : Prediction.t list
      ; hyperparameters : Hyperparameters.t
      }

  let create_hyperparameters (_data : Types.Total_Data.t) = () ;;

  let calculate_model_residual (_data : Types.Total_Data.t) = () ;;

  let create_model (_data : Types.Total_Data.t) (_time_steps : int) = () ;;

  let update_parameters t = t ;;

  let predict_next_price () = () ;;

  let generate_test_dataset (_data : Types.Total_Data.t) = () ;;

  let test_model () = () ;;

end