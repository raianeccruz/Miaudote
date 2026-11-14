<?php

namespace App\Repositories;

use App\Models\Animal;
use App\Models\User;
use Illuminate\Pagination\LengthAwarePaginator;

class AnimalRepository
{
    public function listar(): LengthAwarePaginator
    {
        return Animal::paginate(10);
    }

    public function criar(User $user, array $dados): Animal
    {
        return $user->animais()->create($dados);
    }

    public function buscarPorId(int $id): Animal
    {
        return Animal::findOrFail($id);
    }

    public function atualizar(int $id, array $dados): Animal
    {
        $animal = Animal::findOrFail($id);
        $animal->update($dados);

        return $animal;
    }

    public function deletar(int $id): void
    {
        $animal = Animal::findOrFail($id);
        $animal->delete();
    }

    public function buscarDoUsuario(int $id, int $userId): Animal
    {
        return Animal::where('user_id', $userId)->findOrFail($id);
    }
}