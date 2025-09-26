///select p.id, v.id, p.name, t.name, o.name, v.cost, v.price, v.barcode, v.quantity, b.name, c.name 
///from ProductVariants v, Product p, optionsType t, optionsValue o, brand b, category c
///join where v.product == p.id and v.option_values.contain(o.id) and o.type == t.id, and p.category == c.id and p.brand == b.id