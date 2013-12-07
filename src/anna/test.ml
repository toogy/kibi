let print_array a =
    for i = 0 to Array.length a - 1 do
        Printf.printf "%f\n" a.(i)
    done;
    print_newline ()

let image_to_input file =
    let img = new OcsfmlGraphics.image(`File file) in
    let w, h = img#get_size in
    let a = Array.make (w * h) 0. in
    for j = 0 to h - 1 do
        for i = 0 to w - 1 do
            a.(j * w + i) <- float (abs (1 - (img#get_pixel i j).OcsfmlGraphics.Color.r / 255))
        done
    done; a

let num_to_char = function
    | n when n >= 0 && n < 91 -> String.make 1 (char_of_int (n + 33))
    | _ -> failwith "unknown char"

let array_to_char a =
    let maxi = ref 0 in
    for i = 1 to Array.length a - 1 do
        if a.(i) > a.(!maxi) then
            maxi := i;
    done; num_to_char !maxi

let main () =
begin
    let charcodelist =
      let rec aux = function
        | 33 -> [33]
        | n -> n :: aux (n - 1) in
      aux 122 in
    let nb_chars = List.length charcodelist in
    let net = new Network.network (150., 1., 100., 0.) (32 * 32, nb_chars, nb_chars) in
    CharIdentification.train_network
      net
      "../setgen/out/"
      10000
      10000
      (*~weights:"weights/weights1024x90x90.txt"*)
      charcodelist
      22;
    while true do
        print_string "character: ";
        let c = int_of_char (read_line ()).[0] in
        print_string "font number: ";
        let num = read_line () in
        let file = "../setgen/out/" ^ string_of_int c ^ "/" ^ num ^ ".png" in
        Printf.printf "reading file %S\n" file;
        let a = net#propagate (image_to_input file) in
        print_array a; print_newline ();
        Printf.printf "char: %S\n" (array_to_char a)
    done
end

let _ = main ()
