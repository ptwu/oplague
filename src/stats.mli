(** The representation type for the stats of a virus. *)
type t = {
  infectivity : float;
  severity : float;
  hality : float;
  heat_res : float;
  cold_res : float;
  drug_res : float;
  anti_cure : float;
}