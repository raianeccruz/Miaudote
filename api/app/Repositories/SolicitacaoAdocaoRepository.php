<?php

namespace App\Repositories;

use App\Models\SolicitacaoAdocao;
use App\Models\User;
use App\Models\Animal;

class SolicitacaoAdocaoRepository
{
    public function listar(User $user)
    {
        return SolicitacaoAdocao::with(['animal', 'usuario'])
            ->where('user_id', $user->id)
            ->orWhereHas('animal', function ($query) use ($user) {
                $query->where('user_id', $user->id);
            })
            ->latest()
            ->get();
    }

    public function criar(User $user, int $animalId): SolicitacaoAdocao
    {
        $solicitacao = $user->solicitacoesAdocao()->create([
            'animal_id' => $animalId,
            'status' => 'pendente',
        ]);

        return $solicitacao->load(['animal', 'usuario']); 
    }

    public function buscarPorId(int $id): SolicitacaoAdocao //
    {
        return SolicitacaoAdocao::with(['animal', 'usuario'])
            ->findOrFail($id);
    }

    public function buscarAnimal(int $animalId): Animal
    {
        return Animal::findOrFail($animalId);
    }

    public function buscarSolicitacaoAtiva(int $userId, int $animalId): bool 
    {
        return SolicitacaoAdocao::where('user_id', $userId)
            ->where('animal_id', $animalId)
            ->whereIn('status', ['pendente', 'aceita'])
            ->exists();
    }

    public function atualizarStatus(SolicitacaoAdocao $solicitacao, string $status): SolicitacaoAdocao 
    {
        $solicitacao->update(['status' => $status,]);

        return $solicitacao->load(['animal', 'usuario']);
    }

    public function existeSolicitacaoAtiva(int $userId, int $animalId): bool
    {
        return SolicitacaoAdocao::where('user_id', $userId)
            ->where('animal_id', $animalId)->whereIn('status', ['pendente', 'aceita'])->exists();
    }
}