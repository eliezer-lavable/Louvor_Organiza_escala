import { useState } from "react";
import { Button } from "@/components/ui/button";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from "@/components/ui/dialog";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { supabase } from "@/integrations/supabase/client";
import { useToast } from "@/hooks/use-toast";
import { Pencil, X } from "lucide-react";
import { useEffect } from "react";
import { MemberPhotoUpload } from "@/components/MemberPhotoUpload";

type Member = {
  id: string;
  name: string;
  role: string;
  phone: string | null;
  email: string | null;
  photo_url?: string | null;
};

type EditMemberDialogProps = {
  member: Member;
  onMemberUpdated: () => void;
};

const roleOptions = [
  { value: "vocal", label: "Vocal" },
  { value: "guitarra", label: "Guitarra" },
  { value: "baixo", label: "Baixo" },
  { value: "bateria", label: "Bateria" },
  { value: "teclado", label: "Teclado" },
  { value: "violao", label: "Violão" },
  { value: "tecnico_som", label: "Técnico de Som" },
  { value: "tecnico_imagem", label: "Técnico de Imagem" },
  { value: "ministro", label: "Ministro" },
];

export function EditMemberDialog({ member, onMemberUpdated }: EditMemberDialogProps) {
  const [open, setOpen] = useState(false);
  const [formData, setFormData] = useState({
    name: member.name,
    role: member.role,
    phone: member.phone || "",
    email: member.email || "",
    photo_url: member.photo_url || "",
  });
  const [instruments, setInstruments] = useState<string[]>([]);
  const [instrumentInput, setInstrumentInput] = useState("");
  const [loading, setLoading] = useState(false);
  const { toast } = useToast();

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);

    const { error } = await supabase
      .from("members")
      .update({
        name: formData.name,
        role: formData.role as "vocal" | "guitarra" | "baixo" | "bateria" | "teclado" | "violao" | "tecnico_som" | "tecnico_imagem" | "ministro",
        phone: formData.phone || null,
        email: formData.email || null,
        photo_url: formData.photo_url || null,
      })
      .eq("id", member.id);

    if (error) {
      toast({
        title: "Erro ao atualizar membro",
        description: error.message,
        variant: "destructive",
      });
    } else {
      toast({
        title: "Sucesso",
        description: "Membro atualizado com sucesso.",
      });
      setOpen(false);
      onMemberUpdated();
    }

    try {
      // atualiza instrumentos: remover antigos e inserir os novos
      await supabase.from("member_instruments").delete().eq("member_id", member.id);
      if (instruments.length > 0) {
        await supabase.from("member_instruments").insert(
          instruments.map((inst) => ({ member_id: member.id, instrument: inst }))
        );
      }
    } catch (err) {
      // não bloquear fluxo principal se falhar nesta parte
      console.error("Erro atualizando instrumentos", err);
    }

    setLoading(false);
  };

  useEffect(() => {
    if (!open) return;
    // carregar instrumentos existentes ao abrir diálogo
    (async () => {
      const { data } = await supabase.from("member_instruments").select("instrument").eq("member_id", member.id);
      setInstruments((data || []).map((d: any) => d.instrument));
    })();
  }, [open, member.id]);

  return (
    <Dialog open={open} onOpenChange={setOpen}>
      <DialogTrigger asChild>
        <Button variant="ghost" size="icon">
          <Pencil className="h-4 w-4" />
        </Button>
      </DialogTrigger>
      <DialogContent className="sm:max-w-[425px]">
        <form onSubmit={handleSubmit}>
          <DialogHeader>
            <DialogTitle>Editar Membro</DialogTitle>
            <DialogDescription>
              Atualize as informações do membro
            </DialogDescription>
          </DialogHeader>
          <div className="grid gap-4 py-4">
            <MemberPhotoUpload
              memberId={member.id}
              memberName={formData.name}
              currentPhotoUrl={formData.photo_url}
              onPhotoUploaded={(url) => setFormData({ ...formData, photo_url: url })}
            />
            <div className="grid gap-2">
              <Label htmlFor="name">Nome</Label>
              <Input
                id="name"
                value={formData.name}
                onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                required
              />
            </div>
            <div className="grid gap-2">
              <Label htmlFor="role">Função</Label>
              <Select
                value={formData.role}
                onValueChange={(value) => setFormData({ ...formData, role: value })}
              >
                <SelectTrigger>
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  {roleOptions.map((option) => (
                    <SelectItem key={option.value} value={option.value}>
                      {option.label}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>
            <div className="grid gap-2">
              <Label htmlFor="instruments">Instrumentos</Label>
              <div>
                <div className="flex items-center gap-2 flex-wrap">
                  {instruments.map((inst, idx) => (
                    <span key={idx} className="inline-flex items-center px-2 py-1 rounded bg-muted text-sm">
                      {inst}
                      <button type="button" className="ml-2 text-muted-foreground" onClick={() => setInstruments(instruments.filter((_, i) => i !== idx))}>
                        <X className="h-3 w-3" />
                      </button>
                    </span>
                  ))}
                </div>
                <div className="mt-2 flex gap-2">
                  <Input
                    id="instruments"
                    value={instrumentInput}
                    onChange={(e) => setInstrumentInput(e.target.value)}
                    placeholder="Adicionar instrumento e pressionar Enter"
                    onKeyDown={(e) => {
                      if (e.key === "Enter") {
                        e.preventDefault();
                        const v = instrumentInput.trim();
                        if (v && !instruments.includes(v)) {
                          setInstruments([...instruments, v]);
                        }
                        setInstrumentInput("");
                      }
                    }}
                  />
                  <Button type="button" onClick={() => {
                    const v = instrumentInput.trim();
                    if (v && !instruments.includes(v)) setInstruments([...instruments, v]);
                    setInstrumentInput("");
                  }}>Adicionar</Button>
                </div>
              </div>
            </div>
            <div className="grid gap-2">
              <Label htmlFor="phone">Telefone</Label>
              <Input
                id="phone"
                type="tel"
                value={formData.phone}
                onChange={(e) => setFormData({ ...formData, phone: e.target.value })}
              />
            </div>
            <div className="grid gap-2">
              <Label htmlFor="email">Email</Label>
              <Input
                id="email"
                type="email"
                value={formData.email}
                onChange={(e) => setFormData({ ...formData, email: e.target.value })}
              />
            </div>
          </div>
          <DialogFooter>
            <Button type="submit" disabled={loading}>
              {loading ? "Salvando..." : "Salvar"}
            </Button>
          </DialogFooter>
        </form>
      </DialogContent>
    </Dialog>
  );
}