<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use App\Models\Animal;
use App\Models\User;

class AnimalSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $user = User::inRandomOrder()->first(); // Seleciona um usuário aleatório existente

        if (!$user) {
            $user = User::factory()->create(); // Cria um novo usuário se não houver nenhum existente
        }

        Animal::factory(2)->create([
            'user_id' => $user->id, // Associa o animal ao usuário selecionado
        ]);
    }
}
