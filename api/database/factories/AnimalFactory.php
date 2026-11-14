<?php

namespace Database\Factories;

use App\Models\Animal;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<Animal>
 */
class AnimalFactory extends Factory
{
    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'nome' => fake()->firstName(),
            'especie' => fake()->randomElement(['Cachorro', 'Gato']),
            'idade' => fake()->numberBetween(0, 15),
            'descricao' => fake()->sentence(12),
            'cidade' => fake()->randomElement(['Guarapuava', 'Curitiba', 'Ponta Grossa', 'Londrina', 'Maringá']),
            'estado' => 'PR',
            'status' => 'disponível',
            'imagem' => null,
        ];
    }
}
