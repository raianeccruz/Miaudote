<?php

namespace App\Repositories;

use App\Models\User;

class UserRepository
{
    public function criar(array $dados): User // Cria um novo usuário com os dados fornecidos
    {
        return User::create($dados); // Retorna o usuário recém-criado
    }

    public function buscarPorEmail(string $email): ?User // Busca um usuário pelo email
    {
        return User::where('email', $email)->first(); // Retorna o usuário com base no email fornecido, ou null se não encontrado
    }

    public function revogarTokenAtual(User $user): void // Revoga o token de acesso atual do usuário
    {
        $user->currentAccessToken()->delete();
    }   
}