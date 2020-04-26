type object_phrase = string list

type command = 
  | Quit
  | Upgrades
  | Buy of object_phrase
  | Progress
  | Step of int
  | Cure

exception Empty

exception Malformed

let rec checkempty lst =
  match lst with
  | [] -> []
  | h :: t -> if (h = "") then checkempty t else h :: checkempty t

let parse str =
  let list =
    str |> String.split_on_char ' ' |> List.filter (fun s -> s <> "")
  in
  match list with
  | "upgrades" :: _ -> Upgrades
  | "quit" :: _ -> Quit
  | "progress" :: _ -> Progress
  | "step" :: [] -> Step 1
  | "step" :: t :: [] ->
    (match int_of_string_opt t with 
     | Some l -> Step l
     | None -> raise Malformed)
  | "cure" :: _ -> Cure
  | "buy" :: t -> Buy t
  | [] -> raise Empty
  | _ -> raise Malformed

let build_phrase lst = String.concat " " lst