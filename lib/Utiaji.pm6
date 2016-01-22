use Bailador;

class Utiaji {
    Bailador::import;

    get '/' => sub {
        "Welcome to Utiaji"
    }

    method run {
        baile;
    }
}
