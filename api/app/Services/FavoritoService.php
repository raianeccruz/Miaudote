<?php

namespace App\Services;

use App\Models\User;
use App\Models\Favorito;
use App\Repositories\FavoritoRepository;

class FavoritoService
{
    public function __construct(
        protected FavoritoRepository $repository
    ) {}

    // Lista os favoritos do usuário autenticado.
    public function listar(User $usuario)
    {
        return $this->repository->listar($usuario);
    }

    // Adiciona um animal aos favoritos.
    public function criar(User $usuario, int $animalId): Favorito
    {
        // Busca o animal e confirma que ele existe.
        $animal = $this->repository->buscarAnimal($animalId);

        // Impede que o usuário favorite o próprio animal.
        if ((int) $animal->user_id === (int) $usuario->id) {
            abort(403, 'Você não pode favoritar um animal cadastrado por você.');
        }

        // Impede favoritos duplicados.
        if ($this->repository->existeFavorito($usuario->id, $animalId)) {
            abort(409, 'Este animal já está nos seus favoritos.');
        }

        return $this->repository->criar($usuario, $animalId);
    }

    // Remove um favorito.
    public function remover(User $usuario, int $id): void
    {
        $favorito = $this->repository->buscarPorId($id);

        // Verifica se o favorito pertence ao usuário.
        if ((int) $favorito->user_id !== (int) $usuario->id) {
            abort(403, 'Você não tem permissão para remover este favorito.');
        }

        $this->repository->remover($favorito);
    }
}
