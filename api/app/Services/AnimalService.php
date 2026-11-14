<?php

namespace App\Services;

use App\Models\Animal;
use App\Models\User;
use App\Repositories\AnimalRepository;
use Illuminate\Pagination\LengthAwarePaginator;
use Illuminate\Support\Facades\Storage;

class AnimalService
{
    public function __construct(protected AnimalRepository $animalRepository)
    {}

    public function listar(): LengthAwarePaginator
    {
        return $this->animalRepository->listar();
    }

    public function criar(User $user, array $dados): Animal
    {   
        if (isset($dados['imagem'])) {
            $dados['imagem'] = $dados['imagem']->store('animais', 'public');
        }
        return $this->animalRepository->criar($user, $dados);
    }

    public function buscarPorId(int $id): Animal
    {
        return $this->animalRepository->buscarPorId($id);
    }

    public function atualizar(int $id, array $dados): Animal
    {
        $animal = $this->animalRepository->buscarPorId($id);

        if (isset($dados['imagem'])) {
            $imagemAntiga = $animal->imagem;

            $dados['imagem'] = $dados['imagem']->store('animais', 'public');

            $animal = $this->animalRepository->atualizar($id, $dados);

            if ($imagemAntiga) {
                Storage::disk('public')->delete($imagemAntiga);
            }
            return $animal;
        }
        return $this->animalRepository->atualizar($id, $dados);
    }

    public function deletar(int $id): void
    {
        $this->animalRepository->deletar($id);
    }

    public function buscarDoUsuario(int $id, int $userId): Animal
    {
        return $this->animalRepository->buscarDoUsuario($id, $userId);
    }
}