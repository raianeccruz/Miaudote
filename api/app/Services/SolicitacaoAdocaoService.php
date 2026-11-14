<?php

namespace App\Services;

use App\Models\User;
use App\Models\SolicitacaoAdocao;
use App\Repositories\SolicitacaoAdocaoRepository;

class SolicitacaoAdocaoService
{
    public function __construct(
        protected SolicitacaoAdocaoRepository $repository
    ) {}

    public function listar(User $user)
    {
        return $this->repository->listar($user);
    }

    public function buscar(int $id): SolicitacaoAdocao
    {
        return $this->repository->buscarPorId($id);
    }

    public function criar(User $user, int $animalId): SolicitacaoAdocao
    {
        $animal = $this->repository->buscarAnimal($animalId); // Busca o animal pelo ID

        if ($animal->user_id === $user->id) {
            abort(422, 'Você não pode solicitar a adoção do seu próprio animal.'); // Verifica se o usuário está tentando adotar seu próprio animal
        }

        if ($animal->status !== 'disponivel') {
            abort(422, 'Este animal não está disponível para adoção.'); // Verifica se o animal está disponível para adoção
        }

        if ($this->repository->existeSolicitacaoAtiva($user->id, $animalId)) 
        {
            abort(409, 'Você já possui uma solicitação ativa para este animal.'); // Verifica se o usuário já possui uma solicitação ativa para o mesmo animal
        }

        return $this->repository->criar($user, $animalId); // Cria a solicitação de adoção
    }

    public function atualizarStatus(User $user, int $id, string $status): SolicitacaoAdocao 
    {
        $solicitacao = $this->repository->buscarPorId($id); // Busca a solicitação de adoção pelo ID

        if ($solicitacao->animal->user_id !== $user->id) {
            abort(403, 'Você não tem permissão para responder esta solicitação.'); // Verifica se o usuário é o dono do animal relacionado à solicitação
        }

        if ($solicitacao->status !== 'pendente') {
            abort(422, 'Esta solicitação já foi respondida ou cancelada.'); // Verifica se a solicitação ainda está pendente
        }

        if ($status === 'aceita' && $solicitacao->animal->status !== 'disponivel') {
            abort(422, 'Este animal não está mais disponível.'); // Verifica se o animal ainda está disponível para adoção antes de aceitar a solicitação
        }

        $solicitacao = $this->repository->atualizarStatus($solicitacao, $status);

        if ($status === 'aceita') {
            $solicitacao->animal->update(['status' => 'em_processo',]); // Atualiza o status do animal para 'em_processo'
        }

        return $solicitacao->load(['animal', 'usuario']); // Retorna a solicitação de adoção atualizada com os relacionamentos carregados
    }

    public function cancelar(User $user, int $id): SolicitacaoAdocao 
    {
        $solicitacao = $this->repository->buscarPorId($id); // Busca a solicitação de adoção pelo ID

        if ($solicitacao->user_id !== $user->id) {
            abort(403, 'Você não pode cancelar esta solicitação.'); // Verifica se o usuário é o dono da solicitação antes de permitir o cancelamento
        }

        if ($solicitacao->status !== 'pendente') {
            abort(422, 'Somente solicitações pendentes podem ser canceladas.'); // Verifica se a solicitação ainda está pendente
        }

        return $this->repository->atualizarStatus($solicitacao, 'cancelada'); // Atualiza o status da solicitação para 'cancelada'
    }
}
