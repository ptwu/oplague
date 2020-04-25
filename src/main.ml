let rec command_loop =
  (*if (State.current_room_id st = "treasure_room")
    then if (List.length (Adventure.global_item_names adv) 
    (*= List.length (State.room_items st)*) > 0)
      then (print_string (Adventure.win adv); exit 0)*)
  print_string "Game text here";
  match read_line () with
  | exception End_of_file -> ()
  | input -> begin match Command.parse input with
      | Quit -> exit 0
      | Upgrades -> print_string "Upgrades here"
      | Progress -> print_string "Virus progress here"
      | Cure -> print_string "Cure here"
      | Buy t -> (*begin match State.go (String.concat " " t) adv st with
                   | Illegal -> print_string "You can't do that!"; command_loop adv st
                   | Legal next -> command_loop adv next
                   end*) print_string (String.concat " " ["Buy upgrade"; t])
    end


let play_game =
  (* let adv = Adventure.from_json (Yojson.Basic.from_file f) in
     let st = State.init_state adv in *)
  command_loop


(** [main ()] prompts for the game to play, then starts it. *)
let main () =
  ANSITerminal.(print_string [black; on_red]
                  "\n\nWelcome to #outbreak;;\n");
  print_string  "> ";
  play_game

(* Execute the game engine. *)
let () = main ()