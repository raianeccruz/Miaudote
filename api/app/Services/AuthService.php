<?php

namespace App\Services;

use App\Models\User;
use App\Repositories\UserRepository;
use Illuminate\Support\Facades\Hash;

class AuthService
{
    public function __construct(
        protected UserRepository $userRepository
    ) {}

    public function cadastrar(array $dados): array
    {
        $user = $this->userRepository->criar($dados);

        $token = $user->createToken($user->name)->plainTextToken;

        return [
            'token_type' => 'Bearer',
            'token' => $token,
            'user' => $user,
        ];
    }

    public function login(array $dados): array
    {
        $user = $this->userRepository->buscarPorEmail(
            $dados['email']
        );

        if (!$user || !Hash::check($dados['password'], $user->password)) {
            abort(401, 'E-mail ou senha inválidos.');
        }

        $token = $user->createToken($user->name)->plainTextToken;

        return [
            'token_type' => 'Bearer',
            'token' => $token,
            'user' => $user,
        ];
    }

    public function logout(User $user): void // Revoga o token de acesso atual do usuário
    {
        $this->userRepository->revogarTokenAtual($user);
    }
}