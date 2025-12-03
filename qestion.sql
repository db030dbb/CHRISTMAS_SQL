SELECT species, body_mass_g
FROM penguins
where species IS NOT NULL AND body_mass_g IS NOT NULL
ORDER BY body_mass_g DESC, species;
