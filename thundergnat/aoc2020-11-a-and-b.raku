my $now = now;

# Load data
# Add empty floor around seating area
# to avoid indexing troubles.
my @layout = lines.map: { [flat '.', .comb, '.'] };

my int $cols = +@layout[1];
@layout.unshift: ['.' xx $cols];
@layout.push:    ['.' xx $cols];
my int $rows = +@layout;


# Part 1
# Initialize
my @after = @layout.map: { .clone };
my @seats;


loop {
    @seats = @after.map: { .clone }
    (^$rows).race(:8batch).map: -> int $r {
        for ^$cols -> int $c {
            my str $this = @seats[$r; $c];
            next if $this eq '.';
            my $around = Bag.new( map { @seats[.[0]; .[1]] },
                ($r-1, $c-1), ($r-1, $c), ($r-1, $c+1),
                ($r  , $c-1),             ($r  , $c+1),
                ($r+1, $c-1), ($r+1, $c), ($r+1, $c+1)
            );
            if $this eq 'L' and !$around<#>     { @after[$r; $c] = '#' };
            if $this eq '#' and  $around<#> > 3 { @after[$r; $c] = 'L' };
        }
    }
    last if @after eqv @seats;
}

say 'A: ', @seats.map( {.flat } ).Bag<#>,
    (now - $now).fmt("\t(%.2f seconds)");
$now = now;

# Part two
# Reinitialize
@after = @layout.map: { .clone };
@seats = ();

loop {
    @seats = @after.map: { .clone }
    (^$rows).race(:8batch).map: -> int $r {
        for ^$cols -> int $c {
            my $this = @seats[$r; $c];
            next if $this eq '.';
            my $around = Bag.new( map { nearest |$_ },
                ($r,-1, $c,-1), ($r,-1, $c,0), ($r,-1, $c,1),
                ($r, 0, $c,-1),                ($r, 0, $c,1),
                ($r, 1, $c,-1), ($r, 1, $c,0), ($r, 1, $c,1)
            );
            if $this eq 'L' and !$around<#>     { @after[$r; $c] = '#' };
            if $this eq '#' and  $around<#> > 4 { @after[$r; $c] = 'L' };
        }
    }
    last if @after eqv @seats;
}

say 'B: ', @seats.map( {.flat } ).Bag<#>,
    (now - $now).fmt("\t(%.2f seconds)");

sub nearest (int $row is copy, int $r-incr, int $col is copy, int $c-incr) {
    my int $r-limit = $r-incr > 0 ?? $rows - 1 !! -1;
    my int $c-limit = $c-incr > 0 ?? $cols - 1 !! -1;
    loop {
        $row += $r-incr;
        last if $row == $r-limit;
        $col += $c-incr;
        last if $col == $c-limit;
        my str $char = @seats[$row; $col];
        return $char if $char eq '#'|'L';
    }
    Nil
}
