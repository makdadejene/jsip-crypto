open! Core

(* let get_data () =
  let curr_file = In_channel.read_lines "src/data_input.txt" in
  List.concat_map curr_file ~f:(fun string_line ->
    let line = String.split string_line ~on:',' in
    List.foldi line ~init:[] ~f:(fun index result _curr_line ->
      if index < List.length line - 5
      then (
        let date = List.nth_exn line index in
        let open_ = List.nth_exn line (index + 1) in
        let high = List.nth_exn line (index + 2) in
        let low = List.nth_exn line (index + 3) in
        let close = List.nth_exn line (index + 4) in
        let volume = List.nth_exn line (index + 6) in
        result @ [ date, open_, high, low, close, volume ])
      else result))
;; *)

let get_data coin = 
  let data_file = Types.Crypto.get_data_file coin in 
  let curr_file = In_channel.read_lines data_file in
  let total_data = Types.Total_Data.create coin in 
  List.iter curr_file ~f:(fun line -> 
    let split_line = String.split line ~on: ',' in 
    match split_line with
    | date :: open_:: high :: low :: close :: _ :: volume :: _ -> (
      if not (String.equal open_ "null") then
      let open_, high , low, close , volume = Float.of_string open_, Float.of_string high, Float.of_string low, Float.of_string close, Int.of_string volume in
      let day = Types.Day_Data.create ~date ~open_ ~high ~low ~close ~volume in 
      Types.Total_Data.add_day_data total_data day
    )
    | _ -> () );
  total_data
;;
(* let get_prev_close link = let contents = File_fetcher.fetch_exn Remote
   ~resource:link in let open Soup in parse contents $$ "td[class]" |>
   to_list |> List.filter ~f:(fun x -> String.equal (R.attribute "class" x)
   "Ta(end) Fw(600) Lh(14px)") |> List.filter ~f:(fun x -> String.equal
   (R.attribute "data-test" x) "PREV_CLOSE-value") |> List.map ~f:(fun li ->
   texts li |> String.concat ~sep:"" |> String.strip) |> List.dedup_and_sort
   ~compare:String.compare ;; *)
