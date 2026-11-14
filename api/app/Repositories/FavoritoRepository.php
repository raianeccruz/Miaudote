<?php

namespace App\Repositories;

use App\Models\User;
use App\Models\Animal;
use App\Models\Favorito;

class FavoritoRepository
{
    // Cadastra um novo favorito.
    public function criar(User $usuario, int $animalId): Favorito 
    {
        $favorito = $usuario->favoritos()->create(['animal_id' => $animalId,]);

        return $favorito->load('animal');
    }

    // Lista somente os favoritos do usuário autenticado.
    public function listar(User $usuario)
    {
        return Favorito::with('animal')->where('user_id', $usuario->id)->latest()->get();
    }

    // Busca um favorito pelo identificador.
    public function buscarPorId(int $id): Favorito
    {
        return Favorito::with('animal')->findOrFail($id);
    }

    // Verifica se o animal existe.
    public function buscarAnimal(int $animalId): Animal
    {
        return Animal::findOrFail($animalId);
    }

    // Verifica se o usuário já favoritou esse animal.
    public function existeFavorito(int $usuarioId, int $animalId): bool 
    {
        return Favorito::where('user_id', $usuarioId)->where('animal_id', $animalId)->exists();
    }

    // Remove um favorito.
    public function remover(Favorito $favorito): void
    {
        $favorito->delete();
    }
}