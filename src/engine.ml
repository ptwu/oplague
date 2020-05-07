open Virus
open World
open Country
open Stats
open Upgrades

type status = Init | Playing | Done of bool * float

type t = { virus : Virus.t; world : World.t; shop : Upgrades.t; status : status }

let step_cure_progress w =
  { w with cure_progress = max 100.0 w.cure_progress +. w.cure_rate }

let step_cure_rate w = { w with cure_rate = w.cure_rate *. 1.01 }

let update_status ({ world } as st) =
  let status =
    if world_healthy_pop world = 0 && world_infected_pop world = 0 then
      Done (true, score world)
    else if cure_progress world >= 100.0 then
      Done (false, score world)
    else
      Playing
  in
  {
    st with
    status = status;
  }

(** [(/./) a b] is the floating division of b by a. *)
let ( /./ ) a b = b /. a

(** [step_kill v w] is the resulting world state after one tick of death
    simulation has passed for all countries in [st]. *)
let step_kill { hality } w =
  let chance = hality |> float_of_int |> ( /./ ) 100.0 in
  let round n =
    n |> float_of_int |> ( *. ) chance |> ceil |> int_of_float
  in
  let killed c = infected c |> round |> kill c in
  { w with countries = w.countries |> List.map killed }

(** [step_infect v w] is the resulting world state after one tick of infection
    simulation has passed for all countries in [st]. *)
let step_infect { infectivity } w =
  let chance = infectivity |> float_of_int |> ( /./ ) 100.0 in
  let round n =
    n |> float_of_int |> ( *. ) chance |> ceil |> int_of_float
  in
  let infected c = healthy c |> round |> infect c in
  { w with countries = w.countries |> List.map infected }

(** [step_spread v w] is the resulting world state after one tick of spreading
    simulation has passed for all countries in [st]. *)
let step_spread { infectivity } w =
  let { countries } = w in
  let roll_dry { dry } =
    let chance, neighbors = dry in
    let helper a c =
      if c.population.infected > 0 && List.mem c.id neighbors then 1
      else 0
    in
    let bad_neighbors = List.fold_left helper 0 countries in
    (* if bordering countries are infected, then land infection more likely *)
    Random.int 200 + infectivity < bad_neighbors * chance
  in
  let roll_sea { sea } = Random.int 200 + infectivity < sea in
  let roll_air { air } = Random.int 200 + infectivity < air in
  let spread roll c = if roll c.borders then infect c 1 else c in
  {
    w with
    countries =
      countries
      |> List.map (spread roll_dry)
      |> List.map (spread roll_sea)
      |> List.map (spread roll_air);
  }

(** [step_once st] is the resulting world state after one tick of
    simulation has passed for [st]. *)
let step_once ({ virus; world } as st) =
  let { stats } = virus in
  {
    st with
    world =
      world |> step_cure_progress |> step_cure_rate |> step_kill stats
      |> step_infect stats |> step_spread stats;
  } |> update_status

let rec step n st = if n <= 0 then st else st |> step_once |> step (n - 1)

let purchase name ({ virus; shop; } as st) =
  let comp { id } = id = name in
  match List.find_opt comp shop with
  | None -> st
  | Some u -> { st with virus = upgrade virus u; }

let init (name : string) (cid : country_id) ({ virus; world; status } as st : t) =
  match status with
  | Init ->
    {
      st with
      virus = change_name name virus;
      world = infect_country cid 1 world;
      status = Playing
    }
  | Playing | Done _ -> st

let status_str { world } =
  Printf.sprintf
    "Healthy: %d\nInfected: %d\nDead: %d\nCure Progress: %f out of %d\n\n"
    (world_healthy_pop world)
    (world_infected_pop world)
    (world_dead_pop world) (world |> cure_progress) 100
