address admin {
module Host {
    use StarcoinFramework::Account;
    use StarcoinFramework::Table;
    use StarcoinFramework::NFT;
    use StarcoinFramework::Option;
    use StarcoinFramework::STC::STC;
    use StarcoinFramework::NFT::{MintCapability, NFT};
    use StarcoinFramework::Option::Option;

    struct HoldCap has store,key {
        mintCap:MintCapability<HostNFT>,
    }


    struct Host has store,key {
        host: vector<u8>,
        addr: Option::Option<address>,
        overdue: u64,
    }


    struct HostNFT has store,copy,key,drop {

    }


    struct HostTable  has store, key {
        host: Table::Table<vector<u8>, Host>
    }



    public(script) fun init(signer: signer) {
        let mate = NFT::new_meta(b"host",b"");
        NFT::register_v2<HostNFT>(&signer,mate);
    }


    public(script) fun resolve(input: vector<u8>):Option<address> acquires HostTable {
        let hostTable = borrow_global<HostTable>(@admin);
        let contains = Table::contains(&hostTable.host, *&input);
        if (!contains) {
           return Option::none()
        };
        //  overdue is return None
        *&Table::borrow(&hostTable.host,*&input).addr

    }


    public(script) fun register(signer: signer, input: vector<u8>, years:u8) acquires HostTable, HoldCap {
        let hostTable = borrow_global_mut<HostTable>(@admin);
        let contains = Table::contains(&hostTable.host,*&input);
        assert!(contains, 10003);
        assert!(years > 0, 10004);
        // pay stc
        Account::pay_from<STC>(&signer, @admin, 10000000000);
        Table::add(&mut hostTable.host,*&input,Host{
            host:input,
            addr:Option::none<address>(),
            overdue:11
        });


        let cap = borrow_global_mut<HoldCap>(@admin);
        let mate = NFT::new_meta(input,b"");
        let typeMate = HostNFT{};
        let nft =  NFT::mint_with_cap_v2<HostNFT,HostNFT>(@admin,&mut cap.mintCap,mate,typeMate,typeMate);
        // TODO
        //   move_to(&signer,nft);

    }



    public(script) fun renewal(signer: signer, input: vector<u8>, years:u8) acquires HostTable {


     //  assert!(exists<NFT<HostNFT, HostNFT>>(Signer::address_of(&signer)),10002);

        let hostTable = borrow_global_mut<HostTable>(@admin);
        let contains = Table::contains(&hostTable.host, *&input);
        assert!(contains, 10003);
        assert!(years > 0, 10004);
        // pay stc
        Account::pay_from<STC>(&signer, @admin, 10000000000);
        Table::add(&mut hostTable.host, *&input,Host{
            host:input,
            addr:Option::none<address>(),
            overdue:11

        })
    }


    public(script) fun set_resolve(signer: signer, input: vector<u8>, addr:address) acquires HostTable {
        let hostTable = borrow_global_mut<HostTable>(@admin);
        let contains = Table::contains(&hostTable.host, *&input);
        assert!(contains, 10003);

        let inHost =  Table::borrow_mut(&mut hostTable.host, *&input);
        inHost.addr = Option::some(addr);

    }

    public(script) fun remove_resolve(signer: signer, input: vector<u8>) acquires HostTable {
        let hostTable = borrow_global_mut<HostTable>(@admin);
        let contains = Table::contains(&hostTable.host, *&input);
        assert!(contains, 10003);

        let inHost =  Table::borrow_mut(&mut hostTable.host, *&input);
        inHost.addr = Option::none<address>();
    }


}
}