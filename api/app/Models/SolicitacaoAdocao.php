<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use App\Models\SolicitacaoAdocao;
// use Illuminate\Database\Eloquent\Factories\HasFactory;

class SolicitacaoAdocao extends Model
{
    protected $fillable = [
        'user_id',
        'animal_id',
        'status',
    ];

    protected $table = 'solicitacoes_adocao';

    public function usuario()
    {
        return $this->belongsTo(User::class, 'user_id');
    }

    public function animal()
    {
        return $this->belongsTo(Animal::class);
    }
}