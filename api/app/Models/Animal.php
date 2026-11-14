<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class Animal extends Model
{
    use HasFactory;
    
    protected $fillable = [
        'nome',
        'especie',
        'idade',
        'descricao',
        'cidade',
        'estado',
        'status',
        'imagem',
    ];

    protected $table = 'animais';

    public function usuario()
    {
        return $this->belongsTo(User::class); // Relacionamento com a tabela de usuários
    }

    public function solicitacoesAdocao()
    {
        return $this->hasMany(SolicitacaoAdocao::class); // Relacionamento com a tabela de solicitações de adoção
    }

    public function favoritos()
    {
        return $this->hasMany(Favorito::class); // Relacionamento com a tabela de favoritos
    }
}